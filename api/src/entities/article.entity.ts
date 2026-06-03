import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('articles')
export class Article {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  title: string;

  @Column({ name: 'title_vi', nullable: true })
  titleVi: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ nullable: true })
  source: string; // e.g. 'BBC 中文', 'VOA 中文'

  @Column({ nullable: true })
  link: string;

  @Column({ name: 'hsk_level', nullable: true })
  hskLevel: string; // 'HSK 1', 'HSK 2', ...

  @Column({ default: true })
  active: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
